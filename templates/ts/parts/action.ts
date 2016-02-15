import { IContext } from "../../../configs/context";

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
