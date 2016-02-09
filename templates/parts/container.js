import {
  useDeps, composeWithTracker, composeAll
} from 'mantra-core';
import Component from '../components/$1.jsx';

export const composer = ({context, clearErrors, $2}, onData) => {
  const {Meteor, Collections} = context();
  if (Meteor.subscribe('$3', postId).ready()) {
    //const options = {
    //  sort: {createdAt: -1}
    //};
    const records = Collections.$4.find({$2}, options).fetch();
    onData(null, {records});
  } else {
    onData();
  }
};

export default composeAll(
  composeWithTracker(composer),
  useDeps()
)(Component);
