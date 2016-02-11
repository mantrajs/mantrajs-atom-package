import React from "react";
import {mount} from "react-mounter";

// import {FlowRouter} from "meteor/kadira:flow-router";

import MainLayout from "../core/components/layout.main";
import EiList from "./containers/ei_list_con";

import { IInjectDeps } from "mantra-core";

export default function (injectDeps: IInjectDeps) {
  const MainLayoutCtx = injectDeps(MainLayout);

  // Move these as a module and call this from a main file
  FlowRouter.route("/", {
    name: "ei.list",
    action() {
      mount(MainLayoutCtx, {
        content: () => (<EiList />)
      });
    }
  });
}
