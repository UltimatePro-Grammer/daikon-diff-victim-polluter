# daikon-diff-victim-polluter

Automatically diff victim+polluter invariants with victim invariants. For use with order-dependent flaky tests.

## Usage

### To automatically run all:

```bash
./ddvp.sh <gitURL> <sha> <victim> <polluter> (<module>)
```

### To run scripts individually:

To get the `.inv` files, go to any Java 8 Maven project and run:

```bash
./daikon-gen-victim-polluter.sh <com.example.Test.victimMethod> <com.example.Test.polluterMethod>
```

> **Note**
>
> If you are having problems during the DynComp stage, try setting `NO_DYNCOMP=1`.
> If you are having problems during the Chicory stage, try ignoring individual classes by name using `IGNORED_CLASSES='some|regex'`

Then analyze the generated logs with:

```bash
mvn exec:java -Dexec.args="daikon-pv.inv daikon-victim.inv daikon-polluter.inv"
```

Or:

```bash
mvn package
java -cp target/classes:daikon-5.8.16.jar in.natelev.daikondiffvictimpolluter.DaikonDiffVictimPolluter daikon-pv.inv daikon-victim.inv daikon-polluter.inv
```

Or, go to the folder where you ran `daikon-gen-victim-polluter.sh` and run:

```
/path/to/daikon-diff-victim-polluter.sh
```

Provide a `-o output.dinv` argument to write the results to a file.

To just run the test with the polluter (no logs will be generated):

```bash
./daikon-victim-polluter.sh test <com.example.VictimTest> <com.example.PolluterTest>
```

If the Java process runs out of memory during processing, you should try again with `-XX:MaxRAMPercentage=50.0` or a higher number.
