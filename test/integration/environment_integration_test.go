/*
 * Copyright 2024 KhulnaSoft, Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"): you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

package integration

import (
	"testing"

	testutils "github.com/khulnasoft/khulnasoft-cloud-sdk-go/test/utils"
	"github.com/stretchr/testify/assert"
)

func TestIntegrationEnvironment(t *testing.T) {
	assert.NotEmpty(t, testutils.TestAuthenticationToken)
	assert.NotEmpty(t, testutils.TestSplunkCloudHost)
	assert.NotEmpty(t, testutils.TestTenant)
}
