import ../api

type
  TerminalApi* = object
    open*: proc() {.cdecl.}

var terminalApi*: TerminalApi
