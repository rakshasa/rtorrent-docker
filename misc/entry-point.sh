#!/bin/bash

echo "running" > /stage/self/state

"${@}"

echo "exited" > /stage/self/state
