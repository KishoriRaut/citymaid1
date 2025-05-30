# City Maid Services Platform

A modern web application for connecting domestic workers with employers.

## Features

- Maid profile creation and management
- Employer search and filtering
- Secure contact unlocking system
- Khalti payment integration
- Real-time updates
- Responsive design

## Tech Stack

- Frontend: HTML5, Tailwind CSS, JavaScript
- Backend: Supabase
- Payment: Khalti Payment Gateway
- Build Tool: Vite

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/citymaid-services.git
   cd citymaid-services
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the root directory:
   ```
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   VITE_KHALTI_PUBLIC_KEY=your_khalti_public_key
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Build for production:
   ```bash
   npm run build
   ```

## Project Structure

```
citymaid-services/
├── src/
│   ├── assets/         # Static assets
│   ├── components/     # Reusable components
│   ├── css/           # Styles
│   ├── js/            # JavaScript modules
│   └── pages/         # Page templates
├── public/            # Public assets
├── dist/             # Build output
└── config/           # Configuration files
```

## Development Guidelines

1. **Code Style**
   - Use ESLint for JavaScript linting
   - Use Prettier for code formatting
   - Follow Tailwind CSS best practices

2. **Git Workflow**
   - Create feature branches
   - Write meaningful commit messages
   - Submit pull requests for review

3. **Testing**
   - Test all new features
   - Ensure responsive design
   - Verify payment flows

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
