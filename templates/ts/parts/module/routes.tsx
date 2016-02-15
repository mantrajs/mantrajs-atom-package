import React from "react";
import {mount} from "react-mounter";

//import MainLayout from "../core/components/layout.main";

import { IInjectDeps } from "mantra-core";

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
