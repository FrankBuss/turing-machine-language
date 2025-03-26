"Running positive tests"

$sources = ls *.tml -name

$tests = 0
$successes = 0

foreach ($source in $sources)
{
	$tests++
	rm tmp.tm -ErrorAction SilentlyContinue
	rm tmp.output -ErrorAction SilentlyContinue
	../compiler/compiler $source tmp.tm
	../machine/machine tmp.tm ($source + ".input") tmp.output
	$diff = diff (get-content ($source + ".output")) (get-content tmp.output)
	if ($diff -ne $null)
	{
		write-error ("Test failed: " + $source)
		$diff
		echo ""
	}
	else
	{
		"Test succeeded: " + $source
		$successes++
	}
}

"Running negative tests"

$sources = ls *.neg -name

foreach ($source in $sources)
{
	$tests++
	rm error -ErrorAction SilentlyContinue
	../compiler/compiler $source tmp.tm 2>error
	if ((get-content error) -match "error")
	{
		"Test succeeded: $source"
		$successes++
	}
	else
	{
		write-error "Test failed: $source"
	}
	
}

"$successes out of $tests succeeded"