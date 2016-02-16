# Mantra extensions for Meteor developers

## Quickstart

1. Install plugin in Atom
2. Start the plugin with "ctrl+alt+o"

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

## Configuration:

Plugin can be configured on two levels:

1. **Global configuration** is part of the package configuration pane in Atom and affects all projects that have no project configuration
2. **Project configuration** allow the package to be configured per project in `mantra.cson` file. Options are displayed below. Please save the mantra.cson file in the root of your project in order for settings to take effect. **All templates can be customised** in `mantra.cson` file. Please see the example of the custom template definition for typescript at the end of this documentation file.

```cson
'language': 'js',
'root': '',
'libFolderName': 'lib'
'templates':
  'js':
    'action':
      'content': """
      ...
      """
      'placeHolders': [ Array of placeholders that replace "$n" in the template file ]
    'component': ...
    'container': ...
    'method': ...
    'publication': ...
    'module': [
      'path': '<sub directory name>'
      'files': [
        'name': '<some file name>'
        'content': """
        """
      ]
    ]
```

## Customising looks

If you adopt a naming standard, (e.g. when all actions have suffix `_action.ts`) you can use the awesome [file-icons](https://atom.io/packages/file-icons) package to bring some colors into your Mantra application as portrayed below.

<img width="362" alt="screen shot 2016-02-16 at 22 26 56" src="https://cloud.githubusercontent.com/assets/2682705/13075377/dbf794fa-d4fe-11e5-893a-0e454b9b4c36.png">

This is an exemplary configuration from your user styles.

```less
.container-icon { .fa; content: "\f0f2"}
.action-icon { .fa; content: "\f0e7"}
.component-icon { .fa; content: "\f12e"}
.routes-icon { .fa; content: "\f0e8"}
.publications-icon { .fa; content: "\f0c2"}
.collection-icon { .fa; content: "\f1b3"}

@import "packages/file-icons/styles/colors"; // to use the colours
@import "packages/file-icons/styles/icons";  // to use the defined icons
@import "packages/file-icons/styles/items";

@{pane-tab-selector}, .icon-file-text {
  &[data-name$="container.ts"]           { .medium-red;             } // Colours icon and filename
  &[data-name$="container.ts"]:before   { .container-icon!important; .medium-red!important; } // Colours icon only
  &[data-name$="actions.ts"]   { .medium-blue; } // Colours icon only
  &[data-name$="actions.ts"]:before   { .action-icon!important; .medium-blue!important; } // Colours icon only
  &[data-name$="view.tsx"]   { .medium-green; } // Colours icon only
  &[data-name$="view.tsx"]:before   { .component-icon!important; .medium-green!important; } // Colours icon only

  &[data-name$="layout.tsx"]   { .medium-green; } // Colours icon only
  &[data-name$="layout.tsx"]:before   { .component-icon!important; .medium-green!important; } // Colours icon only

  &[data-name$="publications.ts"]:before   { .publications-icon!important; } // Colours icon only
  &[data-name$="collection.ts"]:before   { .collection-icon!important; } // Colours icon only
  &[data-name$="routes.tsx"]           { .medium-yellow;             } // Colours icon and filename
  &[data-name$="routes.tsx"]:before   { .routes-icon!important; .medium-yellow!important; } // Colours icon only
}

}
```


## Custom templates

Example of the custom template definition

```cson
'language': 'ts',
'root': '',
'libFolderName': 'lib'
'templates':
  'ts':
    'action':
      'content': """
        export default {
          create({Meteor, LocalState}, myParam: string) {
            // e.g. update local state

            //LocalState.set('KEY', null);
            //if (!myParam) {
            //  LocalState.set('ERROR', 'myParam is required.');
            //  return;
            //}

            // e.g. update remote state

            //Meteor.call('posts.createComment', id, postId, text, (err) => {
            //  if (err) {
            //    alert(`Post creating failed: ${err.message}`);
            //  }
            //});
          },

          // e.g. clear local state
          //clearErrors({LocalState}) {
          //  return LocalState.set('ERROR', null);
          //}
        };
      """
      'placeHolders': []
    'component':
      'content': """
      import React from "react";

      interface IProps {
      }

      class $1 extends React.Component<IProps, {}> {
        render() {
          const { error } = this.props;

          return (
            <div>
            </div>
          );
        }
      }

      export default $1;
      """
      'placeHolders': [
        "Component Name"
      ]
    'container':
      'content': """
      import {
        useDeps, composeWithTracker, composeAll
      } from "mantra-core";

      import Component from "../components/$1";
      import { IContext, IKomposer, IKomposerData } from "../../../configs/context";
      import { ICollectionDAO } from "../../../../common/collections";

      interface IProps {
        context: () => IContext;
        clearErrors: Function;
      }

      export const composer: IKomposer = ({context, clearErrors}: IProps, onData: IKomposerData) => {
        const { Meteor, Collections }: IContext = context();
        if (Meteor.subscribe("$3", postId).ready()) {
          const options = {
            sort: {createdAt: -1}
          };
          const data = Collections.$2.find({$2}, options).fetch();
          onData(null, {data});
        } else {
          onData();
        }

        return clearErrors;
      };

      export default composeAll(
        composeWithTracker(composer),
        useDeps()
      )(Component);
      """
      'placeHolders': ["Component Name", "Collection Name", "Subscription"]
    'method':
      'content': """
      // import {Meteor} from 'meteor/meteor';
      // import {check} from 'meteor/check';

      export default function () {
        Meteor.methods({
          '$1'($2) {
            check($2, String);
          }
        });
      }
      """
      'placeHolders': ["Method Name", "Parameters"]
    'publication':
      'content': """
      //import {Meteor} from 'meteor/meteor';
      //import {check} from 'meteor/check';

      export default function () {
        Meteor.publish("$1", function () {
          const selector = {};
          const options = {
            // fields: {_id: 1, title: 1},
            // sort: {createdAt: -1},
            // limit: 10
          };

          return $2.find(selector, options);
        });
      }
      """
      'placeHolders': ["Publication Name", "Collection"]
    'module': [
      'path': 'actions'
      'files': [
        'name': 'index.ts'
        'content': """
        const actions = {
          // ACTION
        };

        export default actions;
        """
      ]
    ,
      'path': 'components'
    ,
      'path': 'containers'
    ,
      'path': '/',
      'files': [
        'name': 'index.ts'
        'content': """
        import actions from "./actions";
        import routes from "./routes";

        import { IContext } from "../../configs/context";

        export default {
          actions,
          routes
        };
        """
      ,
        'name': 'routes.ts'
        'content': """
        import React from "react";
        import { IContext, IInjectDeps, mount } from "../../configs/context";

        export default function (injectDeps: IInjectDeps) {
          //const MainLayoutCtx = injectDeps(MainLayout);

          // Move these as a module and call this from a main file
          // FlowRouter.route("/", {
          //   name: "ei.list",
          //   action() {
          //     mount(MainLayoutCtx, {
          //       content: () => (<EiList />)
          //     });
          //   }
          // });
        }
        """
      ]
    ]
```
