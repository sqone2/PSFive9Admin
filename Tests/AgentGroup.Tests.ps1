$module = "PSFive9Admin"


$agentGroup1_name = "$module-Agent-Group-1"
$agentGroup1_desc = "$module-Agent-Group-1"

$testUser_username = 'agent_group@psfive9admin.co'


Describe "AgentGroup" -Tag "AgentGroup" {

    Context ": Create test agent group" {

        It "Test agent group does not already exist" {
        
            $existingGroup1 = Get-Five9AgentGroup $agentGroup1_name
        
            $existingGroup1 | Should -BeNullOrEmpty
        
        }

        It "Can create new agent group" {

            $agentGroup1 = New-Five9AgentGroup -Name $agentGroup1_name -Description $agentGroup1_desc
        }

        It "Agent group was created correctly" {

            $agentGroup1 = Get-Five9AgentGroup $agentGroup1_name

            $agentGroup1 | Should -Not -BeNullOrEmpty

            $agentGroup1.name | Should -BeExactly $agentGroup1_name
            $agentGroup1.description | Should -BeExactly $agentGroup1_desc
        }

    }

    Context ": Create test user" {

        It "Test user does not exist" {

            $testUser = Get-Five9User $testUser_username

            $testUser | Should -BeNullOrEmpty
        }

        It "Can create test user" {

            $testUserCreation = New-Five9User -DefaultRole: Agent -FirstName "Agent" -LastName "Group" -Username $testUser_username -Email $testUser_username -Password $env:TestAgentPassword -Active $false
        }

        It "Test user was created" {

            $testUser = Get-Five9User $testUser_username

            $testUser | Should -Not -BeNullOrEmpty
        }

    }

    Context ": Add/remove agent to agent group" {

        It "Can add test user to agent group" {

            $addMember = Add-Five9AgentGroupMember -Name $agentGroup1_name -Members $testUser_username
        }

        It "Verify test user was added to group" {

            $members = Get-Five9AgentGroupMember -Name $agentGroup1_name

            $members | Should -Contain $testUser_username
        }
    
        It "Can remove test user from agent group" {

            $removeMember = Remove-Five9AgentGroupMember -Name $agentGroup1_name -Members $testUser_username
        }

        It "Verify test user was removed from group" {

            $members = Get-Five9AgentGroupMember -Name $agentGroup1_name

            $members | Should -Not -Contain $testUser_username
        }

    }


    Context ": Modify agent group" {

        It "Can modify agent group" {
            Set-Five9AgentGroup -Name $agentGroup1_name -NewName $($agentGroup1_name + "_NewName") -Description $($agentGroup1_desc + "_NewDesc")
        }

        It "Agent group was modified correctly" {

            $agentGroup1 = Get-Five9AgentGroup $($agentGroup1_name + "_NewName")

            $agentGroup1 | Should -Not -BeNullOrEmpty

            $agentGroup1.name | Should -BeExactly $($agentGroup1_name + "_NewName")
            $agentGroup1.description | Should -BeExactly $($agentGroup1_desc + "_NewDesc")
        }

    }


    Context ": Clean up test agent and agent group" {

        It "Can delete test user" {

            $deleteUser = Remove-Five9User -Username $testUser_username

        }

        It "Test user does not exist" {

            $testUser = Get-Five9User $testUser_username

            $testUser | Should -BeNullOrEmpty
        }

        It "Can delete agent group" {

            $deleteAgentGroup = Remove-Five9AgentGroup -Name $($agentGroup1_name + "_NewName")
        }

        It "Agent group does not exist" {
        
            $existingGroup1 = Get-Five9AgentGroup $agentGroup1_name
        
            $existingGroup1 | Should -BeNullOrEmpty
        
        }
    }
    


}