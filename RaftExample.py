class RaftNode:
    def __init__(self, node_id, all_node_ids):
        self.node_id = node_id
        self.all_node_ids = all_node_ids
        self.current_term = 0
        self.voted_for = None
        self.log = []
        self.commit_index = 0
        self.last_applied = 0
        self.next_index = {}
        self.match_index = {}
        self.state = 'follower'

    def request_vote(self, candidate_id, term):
        if term < self.current_term:
            return False
        if self.voted_for is None or self.voted_for == candidate_id:
            return True
        return False

    def append_entries(self, leader_id, term, prev_log_index, prev_log_term, entries, leader_commit):
        if term < self.current_term:
            return False

        if prev_log_index > len(self.log):
            return False
        if prev_log_index > 0 and self.log[prev_log_index-1]['term'] != prev_log_term:
            return False

        self.update_log(entries, prev_log_index)
        self.update_commit_index(leader_commit)

        return True

    def update_log(self, entries, prev_log_index):
        for entry in entries:
            if entry['index'] > len(self.log) or self.log[entry['index']-1]['term'] != entry['term']:
                self.log[entry['index']-1:] = [entry]

    def update_commit_index(self, leader_commit):
        if leader_commit > self.commit_index:
            self.commit_index = min(leader_commit, len(self.log))

    def start_election(self):
        self.state = 'candidate'
        self.current_term += 1
        self.voted_for = self.node_id
        # Send RequestVote RPCs to other nodes

    def become_leader(self):
        self.state = 'leader'
        self.next_index = {node_id: len(self.log) + 1 for node_id in self.all_node_ids}
        self.match_index = {node_id: 0 for node_id in self.all_node_ids}
        # Start sending heartbeat AppendEntries RPCs to other nodes

    def run(self):
        while True:
            if self.state == 'follower':
                # Wait for incoming RPCs
                pass
            elif self.state == 'candidate':
                self.start_election()
            elif self.state == 'leader':
                # Send heartbeats
                pass

            # Check for timeouts, handle responses, etc.


all_node_ids = [0, 1, 2, 3, 4]
nodes = [RaftNode(node_id, all_node_ids) for node_id in all_node_ids]

for node in nodes:
    node.run()
