-- One private Broadcast channel per signed-in user: topic "user:{auth.uid()}".
-- Messages are sent only by database triggers (functions phase); clients can't send.
create policy user_channel_receive on realtime.messages
  for select to authenticated
  using (
    realtime.messages.extension = 'broadcast'
    and (select realtime.topic()) = 'user:' || (select auth.uid())::text
  );
