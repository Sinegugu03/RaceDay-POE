# RaceDay

RaceDay is a race-event management system that lets running/sporting event organisers publish events with multiple race categories (e.g. 5km, 10km, Half Marathon), and lets members of the public register as participants, enrol in a category, pay their entry fee, and view their results once the race has taken place.

This repository contains the **Part 1 – System Planning and Database** deliverables: the Entity Relationship Diagram, the API endpoint plan, and the SQL Server database schema and seed script, all located in the [`/docs`](./docs) folder.

## Roles

**Organiser**
Creates and manages events and their race categories, opens/closes enrolment, and captures participant results once a race is complete. An organiser can only edit or delete the events and categories they own.

**Participant**
Registers an account, browses published events, enrols in one or more race categories, pays the associated entry fee, and views their own enrolment status and results.

## Contents of /docs

| File | Description |
|---|---|
| `RaceDay_ERD.png` | Entity Relationship Diagram for the full data model (6 entities) |
| `RaceDay_Endpoint_Plan.md` | Planned REST API endpoints, covering authentication, user profile, events, categories, enrolments, and results |
| `RaceDay_Schema.sql` | SQL Server script that creates the full schema and seeds sample data |

## CI/CD

A GitHub Actions workflow ([`validate-structure.yml`](./.github/workflows/validate-structure.yml)) runs on every push and pull request to `main`. It checks that the `/docs` folder exists and contains the required ERD, endpoint plan, and SQL script files, and that a `README.md` is present at the repository root.

**Successful build screenshot:**

<!-- Replace the line below with an embedded screenshot once you have a green build, e.g.: -->
<!-- ![CI/CD green build](./docs/ci-success-screenshot.png) -->

_<img width="1308" height="829" alt="ci-success-screenshot png" src="https://github.com/user-attachments/assets/0cbca871-4078-4c13-8365-78bd9493aa68" />

_

## Video Walkthrough

Unlisted YouTube video walking through the planning documents, ERD decisions, endpoint plan choices, and a live run of the SQL script in SSMS:


