#!/usr/bin/env bash

after init interactive

function load()
{
  stty ixany
  stty start undef
  stty stop undef
}
