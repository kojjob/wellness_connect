# Comprehensive Prompt for Building the Telehealth & Wellness Platform

## 1. Project Goal & Tech Stack

**Primary Goal:** Develop a complete Ruby on Rails 8 application, "WellnessConnect," that serves as a marketplace for patients to find and book virtual appointments with wellness providers.

**Core Technologies:**
- **Backend:** Ruby on Rails 8
- **Database:** PostgreSQL
- **Frontend:** Hotwire (Turbo & Stimulus), TailwindCSS
- **Authentication:** Devise gem
- **Payments:** Stripe gem
- **File Uploads:** Active Storage

## 2. Core Features for MVP

- **User Authentication:** Secure sign-up and login for Patients, Providers, and Admins using Devise. Role management is critical.
- **Provider Profiles:** Providers can create and manage their public-facing profiles, detailing their specialty, credentials, and bio.
- **Service Management:** Providers can list, define, and price the services they offer (e.g., "45-Minute Coaching Session").
- **Availability Management:** Providers can set and manage their weekly availability for appointments.
- **Patient Booking:** Patients can browse providers, view their services and availability, and book an appointment.
- **Dashboards:** Separate, simple dashboards for patients and providers to view their upcoming and past appointments.

## 3. Data Schema

The complete data schema, including all models, attributes, and associations, is defined in the accompanying file: **`telehealth_wellness_platform.md`**. You must adhere strictly to this data model to ensure relational integrity.

## 4. Step-by-Step Implementation Plan

Please proceed sequentially through the following steps, confirming the completion of each major stage.

**Step 1: Initial Application Setup**
1.  Generate a new Rails 8 application:
    ```bash
    rails new wellness_connect --database=postgresql -c tailwind
    ```
2.  Navigate into the `wellness_connect` directory.
3.  Add necessary gems to the `Gemfile`:
    ```ruby
    gem 'devise'
    gem 'pundit' # For authorization
    gem 'stripe'
    ```
4.  Run `bundle install` and create the database: `rails db:create`.

**Step 2: Authentication & Authorization**
1.  Set up Devise for the `User` model.
2.  Add a `role` column to the `users` table (enum: `patient`, `provider`, `admin`).
3.  Set up Pundit for authorization, creating policies for each model to enforce role-based access (e.g., only providers can edit their own profiles).

**Step 3: Model & Migration Generation**
1.  Using the `telehealth_wellness_platform.md` file as a reference, generate all required models and their corresponding migrations. For example:
    ```bash
    rails g model ProviderProfile user:references specialty:string bio:text
    rails g model Service provider_profile:references name:string description:text duration_minutes:integer price:decimal
    # ... and so on for all other models.
    ```
2.  Implement all `has_many`, `belongs_to`, etc., associations in the `app/models/*.rb` files as specified in the schema.
3.  Run `rails db:migrate`.

**Step 4: Provider-Side Features (Controllers & Views)**
1.  Implement full CRUD functionality for `ProviderProfiles`.
2.  Implement full CRUD functionality for `Services`, nested under the provider's profile.
3.  Implement full CRUD functionality for `Availabilities`, allowing providers to manage their schedules.
4.  Create a provider-specific dashboard to view their appointments.

**Step 5: Patient-Side Features (Controllers & Views)**
1.  Create a public-facing controller/view to browse all providers.
2.  Implement the appointment booking workflow. This should be a multi-step process handled by an `AppointmentsController`:
    - Select a provider -> View services & availability -> Select a time -> Confirm & Pay.
    - Use Turbo Frames and Stimulus to create a smooth, single-page experience for the booking process.
3.  Create a patient-specific dashboard to view their upcoming and past appointments.

**Step 6: Styling**
- Throughout the development process, use TailwindCSS utility classes to style all views. Aim for a clean, modern, and responsive design.

Please begin with Step 1.
