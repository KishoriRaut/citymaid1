# City Maid Platform

A web platform connecting domestic workers with employers in Nepal. The platform allows free posting of profiles and jobs, with contact information unlocked through a secure payment system.

## Features

- **Free Posting**: Both maids and employers can create profiles and post jobs for free
- **Secure Payments**: Contact information is unlocked through Khalti payment integration
- **User Authentication**: Secure sign-up and login system
- **Profile Management**: Create and manage profiles for both maids and employers
- **Search & Filter**: Advanced search and filtering options for finding the perfect match
- **Contact Management**: Track unlocked contacts and payment history
- **Responsive Design**: Mobile-friendly interface for all devices

## Pages

1. **Home Page** (`index.html`)
   - Latest job listings
   - Featured maid profiles
   - Quick access to main features

2. **Find Maids** (`find-maids.html`)
   - Browse available maids
   - Advanced filtering options
   - Contact unlocking system

3. **Find Jobs** (`find-jobs.html`)
   - Browse available jobs
   - Advanced filtering options
   - Contact unlocking system

4. **Create Profile** (`create-profile.html`)
   - Profile creation form for maids
   - Photo upload
   - Detailed service information

5. **Post a Job** (`post-job.html`)
   - Job posting form for employers
   - Service requirements
   - Contact information

6. **Contact Us** (`contact.html`)
   - Contact form
   - Company information
   - Social media links

7. **About Us** (`about.html`)
   - Company information
   - How it works
   - Team information

8. **Sign In** (`signin.html`)
   - User authentication
   - Profile management
   - Payment history

## Technical Details

### Frontend
- HTML5
- CSS3
- JavaScript (ES6+)
- Font Awesome icons
- Responsive design

### Data Storage
- Local Storage (initial implementation)
- Supabase (planned future implementation)

### Payment Integration
- Khalti Payment Gateway
- Demo key for testing

## Getting Started

1. Clone the repository
2. Open `index.html` in your web browser
3. Navigate through the pages using the navigation menu
4. Test the features:
   - Create a profile
   - Post a job
   - Search and filter listings
   - Test the payment system (using demo key)

## Development

### Local Storage Structure
- Users: `users` array
- Maids: `maids` array
- Jobs: `jobs` array
- Contacts: `contacts` array
- Payments: `payments` array

### Payment Integration
The platform uses Khalti's payment gateway for processing payments. A demo key is provided for testing purposes.

## Future Enhancements

1. **Database Migration**
   - Move from Local Storage to Supabase
   - Implement real-time updates
   - Enhanced data security

2. **Additional Features**
   - Review system
   - Advanced messaging
   - Profile verification
   - Background checks

3. **Mobile App**
   - Native mobile applications
   - Push notifications
   - Location-based services

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any queries or support, please contact:
- Email: info@citymaid.com
- Phone: +977-1-4XXXXXX
- Address: 123 Main Street, Kathmandu, Nepal

# City Maid Admin Dashboard

This is the admin dashboard for the City Maid platform, a service that connects domestic helpers with employers in Nepal.

## Features

- Settings management
- User management
- Payment tracking
- Contact unlock management
- System configuration

## Getting Started

1. Clone the repository
2. Open `pages/dashboard/admin/settings.html` in your browser
3. Sign in with admin credentials

## Technology Stack

- HTML5
- Tailwind CSS
- JavaScript
- Supabase for backend
- Khalti for payments

## Security

- Admin authentication required
- Secure payment processing
- Data encryption
- Regular security audits

## License

All rights reserved. This is a private repository.

# City Maid Services - Supabase Setup Guide

This guide will help you set up the Supabase database for the City Maid Services platform.

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. Basic knowledge of SQL

## Setup Steps

### 1. Create a Supabase Project

1. Log in to your Supabase account
2. Click "New Project"
3. Enter a project name (e.g., "city-maid-services")
4. Choose a database password (save this securely)
5. Select a region closest to your users
6. Click "Create new project"

### 2. Get Your API Keys

1. In your project dashboard, go to "Settings" > "API"
2. Copy the "Project URL" and "anon/public" key
3. Update these values in `js/supabase-config.js`:

```javascript
const SUPABASE_URL = 'https://your-project-url.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

### 3. Create Database Tables

1. In your project dashboard, go to "SQL Editor"
2. Create a new query
3. Copy and paste the contents of `sql/create_tables.sql`
4. Run the query to create the necessary tables

### 4. Set Up Authentication

1. In your project dashboard, go to "Authentication" > "Providers"
2. Enable "Email" provider
3. Configure any additional providers as needed (Google, Facebook, etc.)

### 5. Test the Connection

1. Open `test-connection.html` in your browser
2. Sign in to your account
3. Check if the connection test is successful

## Database Schema

### maid_profiles Table

Stores information about maid profiles:

- `id`: UUID (Primary Key)
- `user_id`: UUID (Foreign Key to auth.users)
- `full_name`: Text
- `date_of_birth`: Date
- `gender`: Text
- `marital_status`: Text
- `national_id`: Text
- `email`: Text
- `phone`: Text
- `address`: Text
- `emergency_contact`: Text
- `years_of_experience`: Integer
- `skills`: Text Array
- `languages`: Text Array
- `work_type`: Text
- `expected_salary`: Decimal
- `work_location`: Text
- `additional_notes`: Text
- `profile_photo`: Text
- `previous_work`: JSONB Array
- `created_at`: Timestamp
- `updated_at`: Timestamp

### employer_profiles Table

Stores information about employer profiles:

- `id`: UUID (Primary Key)
- `user_id`: UUID (Foreign Key to auth.users)
- `full_name`: Text
- `email`: Text
- `phone`: Text
- `address`: Text
- `job_title`: Text
- `job_type`: Text
- `salary_range`: Text
- `work_hours`: Text
- `start_date`: Date
- `location`: Text
- `job_description`: Text
- `required_skills`: Text
- `additional_requirements`: Text
- `profile_photo`: Text
- `created_at`: Timestamp
- `updated_at`: Timestamp

## Row Level Security (RLS)

The tables are configured with Row Level Security to ensure users can only access their own data:

- Users can only view their own profiles
- Users can only insert their own profiles
- Users can only update their own profiles

## Troubleshooting

If you encounter issues:

1. Check the browser console for error messages
2. Verify your Supabase URL and API key are correct
3. Ensure the tables are created successfully
4. Make sure you're signed in when testing the connection
5. Check if the RLS policies are applied correctly 
 