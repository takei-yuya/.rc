#!/usr/bin/env bash

after init
after add_path

function load()
{
  MANPATH="$(man -w)"

  function AddPrefix() {
    prefix="$(2>/dev/null cd "${1}" && pwd || echo "${1}")";
    # Runtime path
    AddPathPre PATH "${prefix}/bin";
    AddPathPre LD_LIBRARY_PATH "${prefix}/lib";
    AddPathPre LD_LIBRARY_PATH "${prefix}/lib64";
    AddPathPre MANPATH "${prefix}/share/man";

    # Development path
    AddPathPre C_INCLUDE_PATH "${prefix}/include";
    AddPathPre CPLUS_INCLUDE_PATH "${prefix}/include";
    AddPathPre LIBRARY_PATH "${prefix}/lib";
    AddPathPre LIBRARY_PATH "${prefix}/lib64";
    AddPathPre PKG_CONFIG_PATH "${prefix}/lib/pkgconfig";
    AddPathPre PKG_CONFIG_PATH "${prefix}/lib64/pkgconfig";

    # Export
    export C_INCLUDE_PATH;
    export CPLUS_INCLUDE_PATH;
    export LIBRARY_PATH;
    export PKG_CONFIG_PATH;
    export LD_LIBRARY_PATH;
    export MANPATH;
  }

  function RemovePrefix() {
    prefix="$(2>/dev/null cd "${1}" && pwd || echo "${1}")";
    # Runtime path
    RemovePath PATH "${prefix}/bin";
    RemovePath LD_LIBRARY_PATH "${prefix}/lib";
    RemovePath LD_LIBRARY_PATH "${prefix}/lib64";
    RemovePath MANPATH "${prefix}/share/man";

    # Development path
    RemovePath C_INCLUDE_PATH "${prefix}/include";
    RemovePath CPLUS_INCLUDE_PATH "${prefix}/include";
    RemovePath LIBRARY_PATH "${prefix}/lib";
    RemovePath LIBRARY_PATH "${prefix}/lib64";
    RemovePath PKG_CONFIG_PATH "${prefix}/lib/pkgconfig";
    RemovePath PKG_CONFIG_PATH "${prefix}/lib64/pkgconfig";
  }
}
