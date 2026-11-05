# Appointment Booking Database (P4: SQL Implementation)

SQL Server implementation of our appointment booking system: 17 tables, their constraints, and seed data. The design this is built from (ERD and P3 design document) is in `docs/`.

**Deadline:** Nov 11 (target finish Nov 10).

---

## 1. Repo structure

```
appointment-booking-db/
├── src/
│   └── Tables/                      <- one CREATE TABLE file per table
│       ├── 01_foundation/           
│       ├── 02_booking_core/         
│       ├── 03_staff_time/           
│       ├── 04_outcomes/             
│       └── 05_appointment_service/  
├── scripts/
│   ├── pre-deployment/
│   │   └── drop_all_tables.sql      <- drops all 17 tables, children first
│   └── post-deployment/             <- seed data (INSERTs), one file per cluster
│       └── 01_foundation_data.sql
├── tests/                           <- read-only checks you run after building
│   ├── check_tables.sql
│   └── 01_foundation_data_rows.sql
├── dist/                            <- THE GRADED FILES (see below). Don't edit.
├── docs/                            <- ERD, Design doc
└── README.md
```

### What goes in each folder

**`src/Tables/<cluster>/`**: table definitions only. Each file is named `dbo.<TableName>.sql` and holds one `CREATE TABLE` statement with its PK, identity column, data types, nullability, FKs, and any CHECK or UNIQUE constraints. No INSERTs and no DROPs belong here.

**`scripts/pre-deployment/`**: scripts that run *before* the tables are created. Right now this is just `drop_all_tables.sql`, which already lists all 17 tables, including yours. You don't need to edit it.

**`scripts/post-deployment/`**: seed data that runs *after* the tables exist. Each cluster gets one file named `0X_<cluster>_data.sql` (for example `02_booking_core_data.sql`) with at least 10 rows per table.

**`tests/`**: queries that check the database without changing it. Examples are row counts and confirming that tables exist. Add a `0X_<cluster>_data_rows.sql` for your cluster, following the foundation one as a model.

**`docs/`**: reference material. If the design changes, update the ERD and design doc here.

### ⚠️ `dist/`: the two files we actually submit

`dist/` holds the two deliverables the assignment grades:

| File | Contains |
|---|---|
| `dist/create_database_and_schema.sql` | `CREATE DATABASE`, every `DROP TABLE IF EXISTS`, and every `CREATE TABLE`, all in one file |
| `dist/insert_data.sql` | every `INSERT` from every cluster, all in one file |

These files are **generated, not written by hand**. Will be built during final assembly by copying the per-table files from `src/` and the seed files from `scripts/` into them in the correct order.

- **Never edit anything in `dist/` directly.** If something is wrong, fix it in the original file under `src/` or `scripts/`. The next assembly would overwrite any change made in `dist/`.
- **Don't include `dist/` changes in your pull requests.** Your work goes in `src/`, `scripts/post-deployment/`, and `tests/` only.

---

## 2. Execution order (this is what breaks builds)

A table can only be created after every table it references exists, and it can only be dropped after every table that references it is gone. Running files in the wrong order fails with an FK error.

### ⚠️ Don't run files in folder (alphabetical) order

Alphabetical order is wrong even inside a single folder. `dbo.CancellationPolicy.sql` sorts before `dbo.Location.sql`, but CancellationPolicy references Location. `dbo.Service.sql` sorts before `dbo.ServiceCategory.sql`, but Service references ServiceCategory. **Always use the lists below.**

### Create order (parents first)

| # | Cluster | Tables, in this exact order |
|---|---|---|
| 01 | Foundation | Business → Location → CancellationPolicy → LocationSocialMedia → ServiceCategory → Service |
| 02 | Booking core | Customer → Appointment → PaymentMethod |
| 03 | Staff & time | Staff → StaffService → StaffAvailability → TimeSlot |
| 04 | Outcomes | Payment → Cancellation → Notification |
| 05 | Appointment service | AppointmentService |

Seed data runs in the same order: `01_foundation_data.sql`, then `02_...`, `03_...`, `04_...`, `05_...`.

### Drop order (children first)

Dropping is the exact reverse: AppointmentService first, Business last. You don't have to work this out yourself, because `scripts/pre-deployment/drop_all_tables.sql` already does it for all 17 tables. It uses `DROP TABLE IF EXISTS`, so it runs cleanly even when some tables haven't been created yet.

---

## 3. Testing on your local database

### One-time setup

In SSMS (or Azure Data Studio), create a local database to work in:

```sql
CREATE DATABASE AppointmentBookingDB;
```

Make sure that database is selected in the toolbar dropdown before running anything else. Our scripts use `dbo.` but don't contain a `USE` statement, so they run against whichever database is selected. If `master` is selected, your tables end up in `master`.

### Every time you test (a clean rebuild)

1. **Pull the latest `main`** (see the git workflow below) so you have everyone's merged work.
2. **Drop:** run `scripts/pre-deployment/drop_all_tables.sql`.
3. **Confirm it's empty:** run `tests/check_tables.sql`. It should return no rows.
4. **Create:** run each `src/Tables/` file in the create order above, including the clusters your tables depend on.
5. **Seed:** run each `scripts/post-deployment/` file in the same order.
6. **Verify:** run `tests/check_tables.sql` and every `tests/0X_*_data_rows.sql`. Every row-count check should show `OK`.

What you need to have built before your own cluster:

| 01 Foundation | Build first |
|---|---|
| 02 Booking core | nothing, so you can start right away |
| 03 Staff & time | 01 Foundation |
| 04 Outcomes | 02 Booking core |
| 05 Appointment service | 01, 02, and 03 |

### Why you should always rebuild from scratch

The seed files use hardcoded FK values (for example `LocationID = 3`). This assumes every table was just created, so its identity column starts at 1. If you run a seed file twice, or run it after deleting rows, the IDs shift and the FK values point at the wrong rows or at rows that don't exist. If anything looks off, go back to step 2.

---

## 4. Conventions for writing your files

- **Dialect:** SQL Server (T-SQL) only.
- **Primary keys:** `<Entity>ID INT IDENTITY(1,1) NOT NULL`, for example `StaffID`.
- **Foreign keys:** use the same name as the referenced PK, for example `Staff.LocationID`.
- **Data types:** match the ERD in `docs/`, such as `VARCHAR(n)`, `INT`, `DECIMAL(10,2)`, `DATE`, `TIME`, and `DATETIME`.
- **Name every constraint.** Then an error message tells you which rule failed.
  - `PK_<Table>`, for example `PK_Staff`
  - `FK_<ChildTable>_<ParentTable>`, for example `FK_Staff_Location`
  - `UQ_<Table>_<Column>`, for example `UQ_CancellationPolicy_LocationID`
  - `CK_<Table>_<Column>`, for example `CK_Service_Price`
- **End each statement with `GO`** so each file runs as its own batch.
- **Seed data:** at least 10 rows per table, inserted in dependency order within your file. Escape apostrophes by doubling them (`'Men''s Haircut'`). Make sure the data makes sense, too: a staff member should only perform services offered by their own location's business.
- **CHECK constraints:** the assignment requires at least 3 across the schema. Foundation already has 4 (`CancellationPolicy.NoticePeriod`, `CancellationPolicy.FeeAmount`, `Service.EstimatedDuration`, `Service.Price`), so any you add are a bonus.
- **Use `docs/P3_Database_Design_Document.docx` and the ERD as the source of truth for columns.**

### Foundation data you'll reference

IDs 1–10 in every foundation table correspond to one business each, so Location 1 belongs to Business 1, and so on. A few extra rows show one-to-many relationships:

- **Locations 11–13** are second locations: 11 is Luxe Hair Studio (Business 1), 12 is Urban Cuts (Business 5), and 13 is Tranquil Spa (Business 7).
- **Cancellation policies belong to locations, not businesses.** This changed from P3, and each location has exactly one policy.
- **Services 11–22** add more services to several businesses. Services labeled "(add-on)" in their description are meant for add-on rows in AppointmentService.

To see which services each location can offer (useful when seeding StaffService), run:

```sql
SELECT l.LocationID, b.Name AS Business, s.ServiceID, s.Name AS Service
FROM dbo.Location l
JOIN dbo.Business b        ON b.BusinessID = l.BusinessID
JOIN dbo.ServiceCategory c ON c.BusinessID = b.BusinessID
JOIN dbo.Service s         ON s.ServiceCategoryID = c.ServiceCategoryID
ORDER BY l.LocationID, s.ServiceID;
```

---

## 5. Team git workflow: how to work safely on our project

To keep our main code safe, you cannot push changes directly to the `main` branch. Instead, follow these 4 steps to do your work.

### Step 1: Get the latest code

Before starting any new work, make sure your local project is up to date.

```bash
git checkout main && git pull
```

### Step 2: Create your own work branch

Never work directly on `main`. Create a personal branch named after what you are building.

```bash
git checkout -b name/task-name
```

Example: `git checkout -b sam/03staff-time`

### Step 3: Save and upload your work

As you make changes, save your progress and send it up to GitHub.

```bash
git add .
git commit -m "Briefly describe what you changed"
git push origin feature/your-name-task-name
```

Before you commit, run `git status` to check that you're only adding files in `src/`, `scripts/post-deployment/`, or `tests/`.

### Step 4: Ask for review (pull request)

1. Go to our project page on GitHub.com.
2. You will see a yellow banner saying **"Compare & pull request"**. Click it.
3. Fill out the template form (describe what you did).
4. Submit it.

Before opening the PR, do a full clean rebuild on your local database (section 3) and confirm it runs with no errors. The project lead will review your code. Once it's approved, it will be merged into `main`.

