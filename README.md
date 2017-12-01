# vision-puppetdb

[![Build Status](https://travis-ci.org/vision-it/vision-puppetdb.svg?branch=development)](https://travis-ci.org/vision-it/vision-puppetdb)

## Notes

The SSL Certificates for Jetty need to be put in place (readable) in order to start PuppetDB.

Note also that the certificate needs to contain all alterernative CNs for the PuppetDB node.

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

