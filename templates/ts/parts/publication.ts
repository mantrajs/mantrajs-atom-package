//import {Meteor} from 'meteor/meteor';
//import {check} from 'meteor/check';

export default function () {
  Meteor.publish("$1", function () {
    const selector = {};
    const options = {
      // fields: {_id: 1, title: 1},
      // sort: {createdAt: -1},
      // limit: 10
    };

    return $2.find(selector, options);
  });
}
