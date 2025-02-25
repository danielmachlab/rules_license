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
"""Rules for declaring the licenses used by a package.

"""

load(
    "@rules_license//rules:providers.bzl",
    "LicenseInfo",
    "LicenseKindInfo",
)

# Debugging verbosity
_VERBOSITY = 0

def _debug(loglevel, msg):
    if _VERBOSITY > loglevel:
        print(msg)  # buildifier: disable=print

#
# license()
#

def license_rule_impl(ctx):
    provider = LicenseInfo(
        license_kinds = tuple([k[LicenseKindInfo] for k in ctx.attr.license_kinds]),
        copyright_notice = ctx.attr.copyright_notice,
        package_name = ctx.attr.package_name or ctx.build_file_path.rstrip("/BUILD"),
        package_url = ctx.attr.package_url,
        package_version = ctx.attr.package_version,
        license_text = ctx.file.license_text,
        label = ctx.label,
        namespace = ctx.attr.namespace,
    )
    _debug(0, provider)
    return [provider]

license_impl = rule(
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
        "namespace": attr.string(
            doc = "A human readable name used to organize licenses into categories." +
                  " This is used in google3 to differentiate third party licenses used" +
                  " for compliance versus internal licenses used by SLAsan for internal" +
                  " teams' SLAs.",
        ),
    },
)
