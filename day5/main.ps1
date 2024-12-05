# Day 5: Print Queue

$ErrorActionPreference = "Stop"

function ParseInput {
	param(
		[string] $Path
	)
	$Constraints = [System.Collections.Generic.List[Tuple[Int64, Int64]]]::new()
	$Prints = [System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]::new()

	$Data = Get-Content -Path $Path

	foreach ($Line in $Data) {
		if ($Line -eq "") {
			continue
		}
		if ($Line.Contains("|")) {
			$Before, $After = $Line -split "\|"
			$Entry = [Tuple]::Create([Int64]::Parse($Before), [Int64]::Parse($After))
			$Constraints.Add($Entry)
		}
		else {
			$Prints.Add([System.Collections.Generic.List[Int64]]::new())
			foreach ($Number in ($Line -split ",")) {
				$Prints[-1].Add([Int64]::Parse($Number))
			}
		}
	}

	$Constraints, $Prints
}

function MiddleValue {
	param (
		[System.Collections.Generic.List[Int64]]$List
	)
	$List[($List.Count - 1) / 2]
}

function SplitCorrectFromWrong {
	param (
		[System.Collections.Generic.List[Tuple[Int64, Int64]]]$Rules,
		[System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]$Updates
	)

	$Correct = [System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]::new()
	$Wrong = [System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]::new()

	foreach ($List in $Updates) {
		$IsListValid = $true
		foreach ($Constraint in $Rules) {
			$FirstFound = $false
			$SecondFound = $false
			
			foreach ($Number in $List) {
				if ($Number -eq $Constraint.Item1) {
					if ($SecondFound) {
						$IsListValid = $false
						break
					}
				}
				elseif ($Number -eq $Constraint.Item2) {
					$SecondFound = $true
				}

				if (($Number -eq $Constraint.Item2) -and $FirstFound) {
					break
				}
			}
			if (-not $IsListValid) {
				break
			}
		}
		$IsListValid ? $Correct.Add($List) : $Wrong.Add($List)
	}

	$Correct, $Wrong
}

function FirstPart {
	param (
		[System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]$Updates
	)
	$Sum = 0
	foreach ($List in $Updates) {
		$Sum += MiddleValue -List $List
	}
	$Sum
}

function FixErrors {
	param (
		[System.Collections.Generic.List[Int64]]$List,
		[System.Collections.Generic.List[Tuple[Int64, Int64]]]$Rules
	)
	# If the two numbers are in the wrong order, swap
	# By construction, the first number will always be before the second
	for ($i = 0; $i -lt $List.Count; $i++) {
		for ($j = 0; $j -lt $i; $j++) {
			foreach ($Rule in $Rules) {
				if ($List[$i] -eq $Rule.Item1 -and $List[$j] -eq $Rule.Item2) {
					$List[$i], $List[$j] = $List[$j], $List[$i]
				}
			}
		}
	}
	$List
}

function SecondPart {
	param (
		[System.Collections.Generic.List[Tuple[Int64, Int64]]]$Rules,
		[System.Collections.Generic.List[System.Collections.Generic.List[Int64]]]$Updates
	)

	$Sum = 0
	foreach ($List in $Updates) {
		$Fixed = FixErrors -List $List -Rules $Rules
		$Sum += MiddleValue -List $Fixed
	}
	$Sum
}

$Rules, $Updates = ParseInput -Path ".\input.txt"
$Correct, $Wrong = SplitCorrectFromWrong -Rules $Rules -Updates $Updates

Write-Output "First part result: $(FirstPart -Updates $Correct)"
Write-Output "Second part result: $(SecondPart -Rules $Rules -Updates $Wrong)"