import {
  useDeps, composeWithTracker, composeAll
} from "mantra-core";
import Component from "../components/$1";

import { IContext } from "../../../configs/context";
import { IKomposer, IKomposerData } from "mantra-core";

export const composer: IKomposer = ({context, clearErrors, $2}, onData: IKomposerData) => {
  const { Meteor, Collections }: IContext = context();
  if (Meteor.subscribe("$3", postId).ready()) {
    const options = {
      sort: {createdAt: -1}
    };
    const comments = Collections.$4.find({$2}, options).fetch();
    onData(null, {comments});
  } else {
    onData();
  }

  return clearErrors;
};

export default composeAll(
  composeWithTracker(composer),
  useDeps()
)(Component);
