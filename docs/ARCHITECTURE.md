# Student AI Assistant Architecture

## Layers

### Core

Shared infrastructure used across the application.

Examples:

- Services
- Network
- Database
- AI
- Storage
- Utilities

---

### Shared

Reusable UI components.

Examples:

- Buttons
- Text Fields
- Dialogs
- Layouts
- Animations

---

### Features

Each feature owns its own:

- Data
- Domain
- Presentation
- Providers

Features must not directly depend on other features.

If multiple features need the same code, move it into `core`.