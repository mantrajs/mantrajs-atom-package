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
