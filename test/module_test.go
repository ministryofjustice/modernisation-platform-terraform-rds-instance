package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModule(t *testing.T) {
	t.Parallel()

	workspaceName := "testing-test"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	terraform.Init(t, terraformOptions)
	terraform.WorkspaceSelectOrNew(t, terraformOptions, workspaceName)

	defer terraform.Destroy(t, terraformOptions)

	terraform.Apply(t, terraformOptions)

	// exampleName := terraform.Output(t, terraformOptions, "example_name")

	// assert.Regexp(t, regexp.MustCompile(`^example-name*`), exampleName)
}
