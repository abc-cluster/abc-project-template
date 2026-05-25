# Website Documentation

This section hosts all content related to the project's website, walkthroughs, and case studies.

## Structure

```
website/
├── src/                # Source files for website content
├── assets/             # Images, stylesheets, and other assets
├── walkthroughs/       # Step-by-step guides for using the templates
├── case-studies/       # Real-world examples of using the project
└── output/             # Compiled and published site files
```

## Purpose

- **Walkthroughs**: Provide users with detailed, step-by-step instructions on using templates effectively.
- **Case Studies**: Demonstrate the application of templates in real-world scenarios, showcasing benefits and lessons learned.

## Development and Build

1. Modify content in `src/`, `walkthroughs/`, or `case-studies/`.
2. Build the site:
   ```bash
   quarto render
   ```
3. Check the `output/` directory for the compiled site.

## Customization

- Add more content to the relevant folders.
- Use shared assets to maintain a consistent look and feel.
- Update stylesheets in `assets/` for visual customization.

## Deployment

1. Ensure all content is rendered and located in `output/`.
2. Deploy using your preferred method (FTP, GitHub Pages, etc).

## Good Practices

- Write concise and clear walkthroughs and case studies.
- Ensure examples highlight key templates' features.
- Keep visuals consistent and support them with explanations.

## Examples Provided

- A common usage guide in `walkthroughs/`.
- Sample case studies illustrating successful template applications.
