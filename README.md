# Appointment Booking Database

SQL Server implementation of our appointment booking system: 18 tables with their constraints and seed data (P4), plus stored procedures, functions, views, a trigger, indexes, column encryption, and a Tableau dashboard (P5). The design this is built from (ERD and design document) is in `docs/`.

**Current phase:** P5 · **Deadline:** Wed Dec 2 · **Team submission target:** Tue Dec 1
Tasks, owners, and dates live in the **Appointment Booking System** GitHub project. Each task's description lists its steps and its "Done when" checklist.

---

## 1. Repo structure

```
appointment-booking-db/
├── src/
│   ├── Tables/                          <- one CREATE TABLE file per table
│   │   ├── 01_foundation/
│   │   ├── 02_booking_core/
│   │   ├── 03_staff_time/
│   │   ├── 04_outcomes/
│   │   ├── 05_appointment_service/
│   │   └── 06_audit/                    (P5: audit table for the trigger)
│   ├── Programmability/                 (P5)
│   │   ├── Functions/                   <- fn_ files
│   │   ├── Views/                       <- vw_ files
│   │   ├── StoredProcedures/            <- usp_ files
│   │   └── Triggers/                    <- trg_ files
│   ├── Indexes/                         (P5) <- IX_ files
│   └── Security/                        (P5) <- column encryption
├── scripts/
│   ├── build_dist.sh                    <- assembles dist/ from src/ and scripts/
│   ├── pre-deployment/
│   │   └── drop_all_tables.sql          <- drops every table, children first
│   └── post-deployment/                 <- seed data (INSERTs), one file per cluster
├── tests/                               <- read-only checks you run after building
├── dist/                                <- THE GRADED FILES (see below). Don't edit.
├── docs/
│   └── visualization/                   (P5) <- Tableau workbook, report PDF, data
├── gui/                                 (P5, bonus)
└── README.md
```

### What goes in each folder

**`src/Tables/<cluster>/`**: table definitions only. Each file is named `dbo.<TableName>.sql` and holds one `CREATE TABLE` statement with its PK, identity column, data types, nullability, FKs, and any CHECK or UNIQUE constraints. No INSERTs and no DROPs belong here.

**`src/Programmability/`**: one function, view, procedure, or trigger per file, named after the object (e.g. `dbo.fn_AppointmentTotal.sql`). See the P5 conventions in section 4.

**`src/Indexes/`**: one non-clustered index per file, named after the index.

**`src/Security/`**: the column encryption script (keys, certificate, and encrypting `PaymentMethod.LastFourDigits`).

**`scripts/pre-deployment/`**: scripts that run *before* the tables are created. Right now this is just `drop_all_tables.sql`, which already lists every table. You don't need to edit it.

**`scripts/post-deployment/`**: seed data that runs *after* the tables exist. Each cluster gets one file named `0X_<cluster>_data.sql` with at least 10 rows per table.

**`tests/`**: queries that check the database without changing it. Each cluster has a `0X_<cluster>_data_rows.sql`. Every row they return should show `OK`.

**`docs/`**: reference material. If the design changes, update the ERD and design doc here.

### ⚠️ `dist/`: the files we actually submit

`dist/` holds the graded deliverables. They're **generated, not written by hand**: `scripts/build_dist.sh` copies the files from `src/` and `scripts/` into them in the correct order.

| File | Contains |
|---|---|
| `create_tables.sql` | `CREATE DATABASE` (if needed), every `DROP TABLE IF EXISTS`, every `CREATE TABLE` |
| `insert_script.sql` | every `INSERT`, in dependency order |
| `encryption_script.sql` | keys, certificate, and column encryption |
| `indexes_script.sql` | every non-clustered index |
| `psm_script.sql` | functions → views → procedures → triggers |

Until P5's final assembly, the build still outputs the P4 names (`create_database_and_schema.sql` and `insert_data.sql`). The P5 names above replace them in the last task.

- **Never edit anything in `dist/` directly.** If something is wrong, fix the original file under `src/` or `scripts/`, then rebuild. The next build would overwrite any change made in `dist/`.
- **Don't include `dist/` changes in your pull requests.** Carolina rebuilds `dist/` during assembly.

To rebuild, run this from the repo root in Terminal:

```bash
bash scripts/build_dist.sh
```

---

## 2. Execution order (this is what breaks builds)

A table can only be created after every table it references exists, and it can only be dropped after every table that references it is gone. Running files in the wrong order fails with an FK error.

### ⚠️ Don't run files in folder (alphabetical) order

Alphabetical order is wrong even inside a single folder. `dbo.CancellationPolicy.sql` sorts before `dbo.Location.sql`, but CancellationPolicy references Location. `dbo.Service.sql` sorts before `dbo.ServiceCategory.sql`, but Service references ServiceCategory. **Always use the lists below.**

### Table create order (parents first)

| # | Cluster | Tables, in this exact order |
|---|---|---|
| 01 | Foundation | Business → Location → CancellationPolicy → LocationSocialMedia → ServiceCategory → Service |
| 02 | Booking core | Customer → Appointment → PaymentMethod |
| 03 | Staff & time | Staff → StaffService → StaffAvailability → TimeSlot |
| 04 | Outcomes | Payment → Cancellation → Notification |
| 05 | Appointment service | AppointmentService |
| 06 | Audit | AppointmentServiceAudit |

Seed data runs in the same order: `01_foundation_data.sql`, then `02_...`, `03_...`, `04_...`, `05_...`.

### Drop order (children first)

Dropping is the exact reverse. `scripts/pre-deployment/drop_all_tables.sql` already handles it, using `DROP TABLE IF EXISTS` so it runs cleanly even when some tables haven't been created yet.

### Submission script run order (P5)

```
create_tables.sql → insert_script.sql → encryption_script.sql → indexes_script.sql → psm_script.sql
```

Encryption runs after the inserts because it encrypts rows that already exist. PSM runs last because its objects reference the final table shapes.

---

## 3. Testing on your local database

We're all on Macs, so SQL Server runs in Docker, and we connect with the VS Code MSSQL extension (or `sqlcmd`, installed with `brew install sqlcmd`).

### One-time setup

Create the local database:

```sql
CREATE DATABASE AppointmentBookingDB;
```

Make sure `AppointmentBookingDB` is the selected database before running anything else. Our source files use `dbo.` but don't contain a `USE` statement, so they run against whichever database is selected.

### Every time you test (a clean rebuild)

1. **Pull the latest `main`** (see the git workflow below) so you have everyone's merged work.
2. **Drop:** run `scripts/pre-deployment/drop_all_tables.sql`.
3. **Confirm it's empty:** run `tests/check_tables.sql`. It should return no rows.
4. **Create:** run each `src/Tables/` file in the create order above.
5. **Seed:** run each `scripts/post-deployment/` file in the same order.
6. **P5 objects:** run the encryption script, then the index files, then functions → views → procedures → triggers.
7. **Verify:** run `tests/check_tables.sql` and every `tests/0X_*_data_rows.sql`. Every check should show `OK`.

Or rebuild `dist/` with `bash scripts/build_dist.sh` and run its files in the submission order above.

### Why you should always rebuild from scratch

The seed files use hardcoded FK values (for example `LocationID = 3`). This assumes every table was just created, so its identity column starts at 1. If you run a seed file twice, or run it after deleting rows, the IDs shift and the FK values point at the wrong rows. If anything looks off, go back to step 2.

---

## 4. Conventions

### Tables (P4)

- **Dialect:** SQL Server (T-SQL) only.
- **Primary keys:** `<Entity>ID INT IDENTITY(1,1) NOT NULL`, for example `StaffID`.
- **Foreign keys:** use the same name as the referenced PK, for example `Staff.LocationID`.
- **Data types:** match the ERD in `docs/`.
- **Name every constraint**, so an error message tells you which rule failed:
  - `PK_<Table>`, e.g. `PK_Staff`
  - `FK_<ChildTable>_<ParentTable>`, e.g. `FK_Staff_Location`
  - `UQ_<Table>_<Column>`, e.g. `UQ_CancellationPolicy_LocationID`
  - `CK_<Table>_<Column>`, e.g. `CK_Service_Price`
  - `DF_<Table>_<Column>`, e.g. `DF_Customer_RegistrationDate`
- **End each statement with `GO`** so each file runs as its own batch.
- **Seed data:** at least 10 rows per table, in dependency order within your file. Escape apostrophes by doubling them (`'Men''s Haircut'`).

### Programmability, indexes, and security (P5)

- **Naming prefixes:** `fn_` functions, `vw_` views, `usp_` procedures, `trg_` triggers, `IX_<Table>_<Column>` indexes. **Never use `sp_` for procedures**: SQL Server reserves it for system procedures and looks in `master` first.
- **One object per file**, named after the object, e.g. `dbo.usp_BookAppointment.sql`, with a header comment saying what it does and what uses it.
- **Rerunnable:** every function, view, procedure, and trigger uses `CREATE OR ALTER`. Every index file starts with `DROP INDEX IF EXISTS`.
- **No `WITH SCHEMABINDING`.** A schema-bound view or function stops `create_tables.sql` from dropping its tables on a rerun.
- **Procedures** follow the structure of `usp_BookAppointment`: `SET NOCOUNT ON; SET XACT_ABORT ON;`, then `BEGIN TRY` / `BEGIN TRAN` / `COMMIT`, and in `BEGIN CATCH`: `IF @@TRANCOUNT > 0 ROLLBACK;` followed by `THROW;`.
- **Views:** no `ORDER BY` inside a view. Sort when you query it.
- **Triggers** must handle multi-row changes: join `inserted` and `deleted`, never copy a single value into a variable.

### ⚠️ Encrypted column

`PaymentMethod.LastFourDigits` is encrypted by `encryption_script.sql`. After it runs, the column holds encrypted bytes, not digits. **Don't reference it in any view, function, procedure, or index.** Only the encryption script and its decrypt demo use it.

### Visualization

We're using **Tableau Desktop** (Power BI Desktop is Windows-only, and we're all on Macs). Tableau is free with a student license, which can take a day to approve, so request it early. The dashboard is built from the reporting views. If connecting Tableau to SQL Server is a hassle, export each view to CSV and build from those. Everything goes in `docs/visualization/`.

---

## 5. Team git workflow: how to work safely on our project

To keep our main code safe, you cannot push changes directly to the `main` branch. Instead, follow these 4 steps to do your work.

### Step 1: Get the latest code

```bash
git checkout main && git pull
```

### Step 2: Create your own work branch

Never work directly on `main`. Create a personal branch named after what you are building.

```bash
git checkout -b feature/your-name-task-name
```

Example: `git checkout -b feature/sam-reporting-views`

### Step 3: Save and upload your work

```bash
git add .
git commit -m "Briefly describe what you changed"
git push origin feature/your-name-task-name
```

Before you commit, run `git status` to check that you're only adding files for your task.

### Step 4: Ask for review (pull request)

1. Go to our project page on GitHub.com.
2. Click the yellow **"Compare & pull request"** banner.
3. Describe what you did, and paste the results of the task's "Done when" checks.
4. Submit it.

Before opening the PR, do a full clean rebuild on your local database (section 3) and confirm everything runs with no errors. Once it's approved, it will be merged into `main`.

---

## 6. P5 schedule

| Date | Tasks due |
|---|---|
| Thu Nov 26 | P5-00 Conventions & repo setup |
| Fri Nov 27 | P5-01 Column encryption |
| Sat Nov 28 | P5-02 Indexes · P5-03 UDFs · P5-04 Audit trigger · P5-06 `usp_BookAppointment` + future slots |
| Sun Nov 29 | P5-05 Reporting views · P5-07 Fee UDF + `usp_CancelAppointment` |
| Mon Nov 30 | P5-08 `usp_CompleteAppointment` (noon) · P5-09 Tableau dashboard + PDF · P5-10 GUI (bonus) |
| Tue Dec 1 | P5-11 Final assembly, clean run, **submit** |
| Wed Dec 2 | Official deadline (buffer) |
