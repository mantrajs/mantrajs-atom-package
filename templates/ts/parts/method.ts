import {Meteor} from 'meteor/meteor';
import {check} from 'meteor/check';

// import {Posts, Comments} from '../../common/collections';

export default function () {
  Meteor.methods({
    '$1'($2) {
      check($2, String);
    }
  });
}
