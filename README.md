# vision-puppetdb

[![Build Status](https://travis-ci.org/vision-it/vision-puppetdb.svg?branch=development)](https://travis-ci.org/vision-it/vision-puppetdb)

## Parameter

## Usage

Include in the *Puppetfile*:

```
mod vision_puppetdb:
    :git => 'https://github.com/vision-it/vision-puppetdb.git,
    :ref => 'production'
```

Include in a role/profile:

```puppet
contain ::vision_puppetdb
```

