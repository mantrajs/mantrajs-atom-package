import {createApp} from 'mantra-core';
import initContext from './configs/context';
// INSERT IMPORT

// modules

// init context
const context = initContext();

// create app
const app = createApp(context);
// INSERT MODULE
app.init();
