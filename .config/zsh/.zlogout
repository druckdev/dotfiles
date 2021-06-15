# Kill ssh-agent if it was created in this session
! (( LAUNCHED_SSH_AGENT && SSH_AGENT_PID )) || kill "$SSH_AGENT_PID"
