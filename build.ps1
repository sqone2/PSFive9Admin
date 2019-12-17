
Invoke-Build -Task Test -Result result
if ($result.Error)
{
    exit 1
}
else 
{
    exit 0
}