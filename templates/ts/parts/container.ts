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

export const composer: IKomposer = ({context, clearErrors, $2}: IProps, onData: IKomposerData) => {
  const { Meteor, Collections }: IContext = context();
  if (Meteor.subscribe("$3", postId).ready()) {
    const options = {
      sort: {createdAt: -1}
    };
    const data = Collections.$4.find({$2}, options).fetch();
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
