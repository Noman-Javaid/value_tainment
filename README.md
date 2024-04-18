# Minnect Web

## Overview

This application is intended to be the Minnect back-end server.

It provides two things:

- An administration panel, that can be accessed at the `/admin` path.
- A REST JSON API to consume and provide data to both Android and iOS applications.

## Getting Started

### Prerequisites
- ruby 3.0.1
- bundler 2.2.17
- postgresql >= 12
- node 14.20.0

## Installation

1. Clone this repository:
```bash
$ git clone git@github.com:koombea/Valuetainment-web.git
```
2. Go to the folder and get the dependencies:
```bash
$ cd Valuetainment-web
$ bundle install
```
3. Install required node version:
```bash
$ nvm install 14.20
$ nvm use 14.20
```
4. Install latest version of [Yarn](https://classic.yarnpkg.com/en/docs/install/#mac-stable)
```bash
$ npm install -g yarn
$ yarn install
```
5. Get your local copy of the environment variables:
```bash
$ cp .env.example .env # Don't forget to update them!
```
6. Create, setup, and generate seeds in the database:
```bash
$ rails db:setup
```
7. Run tests:
```bash
$ rails db:test:prepare
$ bundle exec rspec
```
*The coverage of tests can be verified opening: ./coverage/index.html*

8. Run the application:
```bash
$ rails s
$ bin/webpack-dev-server
```
9. Now, you can open http://localhost:3000 (or http://localhost:3000/admin) in your browser.

## Conventions

### Internal error codes

The following codes were implemented to identify specific errors when two factor authentication is used:

```
code: auth-001, when two factor code is required
code: auth-002, when two factor code is invalid
```

## Environments

### Production

### Staging

## Troubleshooting

## Contributing

The `master` branch of this repository contains the latest stable source code for the production environment. This branch and the `dev` branch are protected to prevent those from being accidentally deleted. Force pushes are also disabled to enforce following the process described in the [Releasing](#releasing) section.

Please follow this steps for submitting any changes:

1. Create a new branch for any new feature.
2. Make sure you include tests for your changes.
3. When the feature is complete, create a pull request to the develop branch.
4. Always squash and merge your PR to develop branch.

### Continuous Integration

When a pull requests is submitted to the `dev` branch the CI service will automatically run the tests and generate a new build for testing. A message will be posted to the team's slack channel.

For more information, see our [CONTRIBUTING](../Shared/CONTRIBUTING.md) guide.

## Releasing

All releases to the main branches (`master` and `dev`) must be code reviewed and approved before being merged by the team's _Release Manager_ following this steps:

1. After a pull request is submitted, the developer must assign the teammates to make a code review.
2. Once the code review is finished and changes are approved, the _QA Analyst_ would be automatically(?) notified to do the smoke testing.
3. If all tests passes, and the _QA Analyst_ does not find any issue the code can be merged by the _Release Manager_.
4. When all the features planned for a release are done, the _Release Manager_ will be in charge of approving and merging the changes to the `master` branch.
5. The _QA Analyst_ must do a full regression test of the production environment to make sure the new changes did not affect any other functionality.

### Checklist

Fill out all the relevant information following the PR template and make sure to add visual documentation to help the reviewer understand what to expect of your changes.

### Continuous Integration

When a change is merged into the `dev` branch the CI service will automatically run the tests and generate a new build for staging. A message will be posted to the team's slack channel.

When a change is merged into the `master` branch the CI service will automatically run the tests and generate a new build for production. A message will be posted to the team's slack channel.

For more information, see our [RELEASING](RELEASING.md) guide.

## License

Copyright © 2022 Koombea¨. All rights reserved.
