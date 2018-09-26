const fs = require('fs');
const _ = require('lodash');
const request = require('request');

const reviewerPath = '../reviewers.json';
const { SLACK_WEBHOOK_URL } = JSON.parse(
  fs.readFileSync('../config.json', 'utf8')
);
let reviewerList = JSON.parse(fs.readFileSync(reviewerPath, 'utf8'));
let availableReviewers = _.filter(reviewerList, { reviewing: true });

if (availableReviewers.length === 0) {
  reviewerList = _.forEach(reviewerList, reviewer => {
    reviewer.reviewing = true;
    return reviewer;
  });
  availableReviewers = _.filter(reviewerList, { reviewing: true });
}

const nominatedReviewer = _.sample(availableReviewers);
nominatedReviewer.reviewing = false;
nominatedReviewer.last_selection = new Date().toISOString();

request({
  uri: SLACK_WEBHOOK_URL,
  method: 'POST',
  body: JSON.stringify({
    text: `Node says: ${nominatedReviewer.name}`,
    channel: '#ehco'
  }),
  headers: { 'Content-Type': 'application/json' }
});

console.log(nominatedReviewer);

fs.writeFileSync(reviewerPath, JSON.stringify(reviewerList, null, 2), 'utf8');
