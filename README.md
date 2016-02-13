# Mantra extensions for Meteor developers

## Quickstart

1. Install plugin in Atom
2. Start the plugin with "ctrl+alt+o"

## Configuration:

Plugin can be configured on two levels:

1. **Global configuration** is part of the package configuration pane in Atom and affects all projects that have no project configuration
2. **Project configuration** allow the package to be configured per project in `mantra.json` file. Options are displayed below. Please save the mantra.json file in the root of your project in order for settings to take effect.

```json
{
  "language": "js",
  "root": "",
  "libFolderName": "lib"
}
```

## Functionality:

- custom pane to display Mantra modules and components
- automatically generate a module
- automatically generate module components from the menu
- generate server components
- several snippets for mantra components ()
- init a new mantra app automatically


1. Code generation - It is possible now to modify the generated code based on placeholders (*here I would like feedback on possible template structure and placeholders*). Also, please not, how components are automatically registered inside index.js

  ![components](https://cloud.githubusercontent.com/assets/2682705/12999539/9f73196c-d1a4-11e5-9a49-8d898d40904e.gif)

2. Similar functionality for modifying placeholders works for module components

  ![modulecomponents](https://cloud.githubusercontent.com/assets/2682705/12999551/b5078e8e-d1a4-11e5-8187-520b4337a94b.gif)

3. When new module is created it automatically creates all necessary directories and register module in `main.js` of the mantra app

  ![modulenew](https://cloud.githubusercontent.com/assets/2682705/12999570/e1bd8050-d1a4-11e5-9bad-0c497e632d76.gif)

4. It is possible to initialise all directories and mantra files in the empty Meteor project just by toggling the mantra plugin

  ![lazyinit](https://cloud.githubusercontent.com/assets/2682705/12999580/f4a0b930-d1a4-11e5-922a-9411fc374425.gif)

5. Mantra plugin settings are kept in the mantra.json file

6. Context menu was disabled in mantra pane, as this led to problems with file deletion, which often led to unexpected deletes.

Please let me know.
