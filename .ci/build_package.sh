#!/bin/bash

dpkg-deb --build --root-owner-group package
dpkg-name package.deb
