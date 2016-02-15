import * as Collections from "../../common/collections";
import ApplicationState from "../utils/application_state";

// import {Meteor} from 'meteor/meteor';
// import {FlowRouter} from 'meteor/kadira:flow-router';
// import {ReactiveDict} from 'meteor/reactive-dict';
// import {Tracker} from 'meteor/tracker';

export { IKomposer, IKomposerData } from "mantra-core";

export interface IContext {
  Meteor: typeof Meteor;
  FlowRouter: typeof FlowRouter;
  Collections: typeof Collections;
  LocalState: ReactiveDict;
  Tracker: typeof Tracker;
}

export default function () {
  return {
    Meteor,
    FlowRouter,
    Collections,
    LocalState: new ReactiveDict(),
  };
}
