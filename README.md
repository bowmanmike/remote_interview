# RemoteInterview

## Setup

1. Install dependencies with `mix deps.get`
2. Create and migrate your database with `mix ecto.setup`
3. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
4. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Design Choices

Because of the scale required for this exercise, there were some significant
scale-related questions to answer, primarily around database interactions.

### Seeding the DB

Inserting 1 million records is not a trivial number, and it takes an
appreciable amount of time. The naive solutions is to just insert 1,000,000
records, one at a time. This takes a prohibitively long time. Given we're
seeding simulated data, my approach is to use `Repo.insert_all/2` to bulk
insert the records in chunks of 10,000. This batch size can be adjusted, but I
found this to be a reasonable number. At this setting, the `mix ecto.setup`
script takes around ~11 seconds to run on my machine. This approach works here
because we're inserting all the records with the same values, so we have a
fairly simple implementation.

The biggest trade-off here is that`Repo.insert_all/2` skips many of the things
Ecto normally handles for you. The biggest missing piece in this case is the
`inserted_at` and `updated_at` timestamps, which we need to set manually.
However, as mentioned, since this is test data, that's a tradeoff I was happy
to make. If each record required more variety across the table, or if we had a
complex set of associations we needed to insert, that would significantly
change the calculation.

### Randomizing the User Points

This is another challenging issue, due to the scale of the table. Iterating
through the table one-by-one was quickly disqualified as far too slow. Since
this process needs to run every minute, the length of the processing should
certainly take a small fraction of that interval. To handle this in a
reasonable timeframe, I came up with two approaches. Once I confirmed that both
approach worked, I used [Benchee](https://github.com/bencheeorg/benchee) to
compare the two, and determine which approach was faster.

#### First Approach -- `Repo.update_all/2`

My first approach was to just use `Repo.update_all/2`, similar to how I managed
the scale in `priv/repo/seeds.exs`. The biggest advantage of this approach is
how simple it is. There's very little mental overhead, it's very
straightforward in it's operation. The main downside is that it bypasses the
normal Ecto Schema and Changeset process, which means we are less protected
from invalid data, and we need to handle more data manually. However, since
there is no user input being provided, we can be certain that the data is
valid. This approach is defined as `RemoteInterview.User.randomize_points_update_all`.

#### Second Approach -- `Task.async_stream/3`

I wondered if running the update with multiple asynchronous tasks might speed
things up. Ultimately, this approach also worked. However, I determined that
this approach had too much overhead, and felt more brittle in it's
implementation. If the batch sizes were too low, the system would run out of
database pool connections. If the batch sizes were too high, the potential
speed gains would be negated. This approach also had positive sides. Mainly, it
worked through the normal Ecto Schema and Changeset functions, so we had more
thorough data validations, and less manual updating of fields.

#### Benchmark Results & Final Decision

These two approaches were compared using Benchee, and the code in
`RemoteInterview.Benchmarks`. The results of the benchmarks are shown here.

```shell
Name                 ips        average  deviation         median         99th %
async              0.112         8.91 s    ±22.98%         9.59 s        11.07 s
update_all        0.0993        10.07 s    ±16.00%        10.56 s        12.56 s

Comparison:
async              0.112
update_all        0.0993 - 1.13x slower +1.16 s
```

Interestingly, both approaches were very similar in terms of execution time. I
was somewhat surprised, expecting the second approach (`Task.async_stream/3`)
to be more significantly faster. Given the closeness of the results, I decided
to go with the `Repo.update_all/2` approach, as I appreciate the lower mental
overhead. However, given the closeness of the benchmarks, I think either
approach could be chosen on their own merits, depending on the preferences of
the author.
