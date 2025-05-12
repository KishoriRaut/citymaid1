# Admin Dashboard Documentation

## Overview
The admin dashboard provides a centralized interface for managing City Maid Services. It displays key metrics and recent activities, allowing administrators to monitor and manage the platform effectively.

## Features

### 1. Authentication
- Admin-only access
- Automatic redirection to login page for unauthorized users
- Secure session management

### 2. Dashboard Statistics
- Total Users Count
- Total Maids Count
- Active Bookings Count
- Total Revenue Display

### 3. Recent Activity Log
- Real-time activity tracking
- Activity types: booking, user, maid, payment
- Timestamp and description for each activity

## Technical Implementation

### Database Tables
1. `activity_log`
   - Tracks all admin activities
   - Fields: id, type, description, created_at, user_id, metadata
   - Row Level Security (RLS) enabled

### Security
- Row Level Security (RLS) policies for data protection
- Admin-only access to sensitive operations
- Secure authentication checks

### Dependencies
- Supabase for backend services
- Tailwind CSS for styling
- Font Awesome for icons

## File Structure
```
admin/
├── dashboard.html      # Main dashboard interface
├── users.html         # (Planned) User management
├── maids.html         # (Planned) Maid management
└── README.md          # This documentation
```

## Setup Requirements
1. Supabase Configuration
   - Valid Supabase URL and API key
   - Proper database tables and RLS policies
   - Admin user role setup

2. Required Tables
   - profiles
   - maid_profiles
   - bookings
   - activity_log

## Usage Guide

### Accessing the Dashboard
1. Navigate to `/admin/dashboard.html`
2. Log in with admin credentials
3. View statistics and recent activities

### Logging Activities
Use the `log_activity` function to record admin actions:
```sql
SELECT log_activity(
    'type',           -- booking, user, maid, or payment
    'description',    -- Activity description
    'metadata'        -- Optional JSON metadata
);
```

### Error Handling
- Authentication errors redirect to login
- Database errors are logged to console
- User-friendly error messages displayed

## Future Enhancements
1. User Management Interface
2. Maid Management System
3. Advanced Analytics
4. Export Functionality
5. Custom Activity Filters

## Maintenance
- Regular security updates
- Database optimization
- Performance monitoring
- Backup procedures

## Troubleshooting
Common issues and solutions:
1. Authentication Failures
   - Check admin role in profiles table
   - Verify Supabase configuration
   - Clear browser cache

2. Data Loading Issues
   - Verify database connections
   - Check RLS policies
   - Validate table structures

## Contact
For technical support or questions:
- Development Team: [Contact Information]
- Database Admin: [Contact Information]
- Security Team: [Contact Information] 