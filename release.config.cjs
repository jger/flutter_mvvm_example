/** @type {import('semantic-release').Options} */
module.exports = {
  branches: ['main', 'master'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    [
      '@semantic-release/exec',
      {
        prepareCmd:
          'node scripts/bump-pubspec-version.js <%= nextRelease.version %>',
      },
    ],
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md', 'app/pubspec.yaml'],
        message: 'chore(release): <%= nextRelease.version %> [skip ci]',
      },
    ],
    '@semantic-release/github',
  ],
};
