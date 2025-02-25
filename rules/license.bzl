# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Rules for declaring the compliance licenses used by a package.

"""

load(
    "@rules_license//rules:providers.bzl",
    "LicenseKindInfo",
)
load(
    "@rules_license//rules:license_impl.bzl",
    "license_rule_impl",
)

_license = rule(
    implementation = license_rule_impl,
    attrs = {
        "license_kinds": attr.label_list(
            mandatory = False,
            doc = "License kind(s) of this license. If multiple license kinds are" +
                  " listed in the LICENSE file, and they all apply, then all" +
                  " should be listed here. If the user can choose a single one" +
                  " of many, then only list one here.",
            providers = [LicenseKindInfo],
            cfg = "exec",
        ),
        "copyright_notice": attr.string(
            doc = "Copyright notice.",
        ),
        "license_text": attr.label(
            allow_single_file = True,
            default = "LICENSE",
            doc = "The license file.",
        ),
        "package_name": attr.string(
            doc = "A human readable name identifying this package." +
                  " This may be used to produce an index of OSS packages used by" +
                  " an applicatation.",
        ),
        "package_url": attr.string(
            doc = "The URL this instance of the package was download from." +
                  " This may be used to produce an index of OSS packages used by" +
                  " an applicatation.",
        ),
        "package_version": attr.string(
            doc = "A human readable version string identifying this package." +
                  " This may be used to produce an index of OSS packages used" +
                  " by an applicatation.  It should be a value that" +
                  " increases over time, rather than a commit hash."
        ),
        "namespace": attr.string(
            doc = "A human readable name used to organize licenses into categories." +
                  " This is used in google3 to differentiate third party licenses used" +
                  " for compliance versus internal licenses used by SLAsan for internal" +
                  " teams' SLAs.",
        ),
    },
)

# buildifier: disable=function-docstring-args
def license(
        name,
        license_text = "LICENSE",
        license_kind = None,
        license_kinds = None,
        copyright_notice = None,
        package_name = None,
        package_url = None,
        package_version = None,
        namespace = "compliance",
        tags = [],
        visibility = ["//visibility:public"]):
    """Wrapper for license rule.

    @wraps(_license)

    Args:
      name: str target name.
      license_text: str Filename of the license file
      license_kind: label a single license_kind. Only one of license_kind or license_kinds may
                    be specified
      license_kinds: list(label) list of license_kind targets.
      copyright_notice: str Copyright notice associated with this package.
      package_name: str A human readable name identifying this package. This
                    may be used to produce an index of OSS packages used by
                    an application.
      package_url: str The canonical URL this package was downloaded from.
      package_version: str The version corresponding the the URL.
      namespace: str Undocumened. Internal.
      tags: list(str) tags applied to the rule
      visibility: list(label) visibility spec.
    """
    if license_kind:
        if license_kinds:
            fail("Can not use both license_kind and license_kinds")
        license_kinds = [license_kind]

    # Make sure the file exists as named in the rule. A glob expression that
    # expands to the name of the file is not acceptable.
    srcs = native.glob([license_text])
    if len(srcs) != 1 or srcs[0] != license_text:
        fail("Specified license file doesn't exist: %s" % license_text)

    _license(
        name = name,
        license_kinds = license_kinds,
        license_text = license_text,
        copyright_notice = copyright_notice,
        package_name = package_name,
        package_url = package_url,
        package_version = package_version,
        namespace = namespace,
        applicable_licenses = [],
        visibility = visibility,
        tags = tags,
        testonly = 0,
    )
