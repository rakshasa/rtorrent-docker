#!/bin/bash

echo "staging" > /stage/self/state



echo "running" > /stage/self/state

"${@}"

echo "exited" > /stage/self/state
