#define N 5
#define BUFSIZE 10

mtype = { candidate, leader };
chan c[N] = [BUFSIZE] of { mtype, byte };

byte num_leaders = 0;

proctype node(chan prev, next; byte my_id)
{
  byte in_id;
  byte leader_id;

  // init: pass the node id to its neighbour
  next!candidate(my_id);

  do
    :: prev?candidate(in_id) ->
      if
        :: in_id > my_id ->
            next!candidate(in_id);
        :: in_id < my_id ->
            skip;
        :: else ->
elected:
            num_leaders++;
            printf("I am the leader! (pid: %d, id: %d)\n", _pid, my_id);
            next!leader(my_id);
      fi
    :: prev?leader(leader_id) ->
      if
        :: leader_id > my_id ->
            next!leader(leader_id);
            break;
        :: else ->
            assert(my_id == leader_id);
            break;
      fi
  od;
  assert(num_leaders == 1);
  // NOTE: if more than one node
  // declares itself as leader, then
  // this assertion will fail for
  // at least one node!
}

init {
  byte proc;
  byte i;

  // here atomic is 'used' to delay all the nodes, so that they
  // start executing after the initialization has finished
  atomic {
    chan prev, next;
    byte id;
    do
      :: i < N -> i++;
      :: true -> break;
    od;
    do
      :: proc < N ->
           prev = c[proc];
           next = c[(proc+1)%N];
           id = (N+i-proc)%N;
           printf("Starting process with id %d.\n", id);
           run node(prev, next, id);
           proc++;
      :: else -> break;
    od
  }
}

/* eventually, a leader is elected */
ltl p1 {<> (num_leaders > 0)}

/* there can be at most one leader */
ltl p2 {[] !(num_leaders > 1)}

/* after a process is elected, it will remain leader forever */
ltl p3 {[] (
                (node[1]@elected -> X [](num_leaders == 1)) &&
                (node[2]@elected -> X [](num_leaders == 1)) &&
                (node[3]@elected -> X [](num_leaders == 1)) &&
                (node[4]@elected -> X [](num_leaders == 1)) &&
                (node[5]@elected -> X [](num_leaders == 1))
            )
}
