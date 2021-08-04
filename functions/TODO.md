Libtorrent/Rtorrent
===================

 * Run autoupdate.
 * Refactor test_tracker_list.
 * Refacotr http stream to use shared_ptr.



Use this the following idea to replace current code used to execute
commands. Do the command thing first, leave the rest for later.

 * Spawn a module loader at the very start of main(...).
   * Thread first, move to fork when the modules support it.
   * Each process has it's own group of services that it shares resources with.
   * The spawner process remains almost as exactly as right after start.
   * Only handles simple requests to spawn processes, then hands back the fd's requested to the hub.
   * The hub is first initialized, it asks spawner to start main thread.
   * Making executing external programs a temporary module would clean up a lot of code.
