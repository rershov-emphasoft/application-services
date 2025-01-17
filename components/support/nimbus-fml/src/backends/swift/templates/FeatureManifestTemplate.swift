// This file was autogenerated by some hot garbage in the `nimbus-fml` crate.
// Trust me, you don't want to mess with it!

{%- for imported_module in self.imports() %}
#if canImport({{ imported_module }})
    import {{ imported_module }}
#endif
{%- endfor %}

{% let nimbus_object = self.config.nimbus_object_name() -%}
///
/// An object for safely accessing feature configuration from Nimbus.
///
/// This is generated.
public class {{ nimbus_object }} {
    ///
    /// This should be populated at app launch; this method of initializing features
    /// will be removed in favor of the `initialize` function.
    ///
    public var api: FeaturesInterface?

    ///
    /// This method should be called as early in the startup sequence of the app as possible.
    /// This is to connect the Nimbus SDK (and thus server) with the `{{ nimbus_object }}`
    /// class.
    ///
    /// The lambda MUST be threadsafe in its own right.
    public func initialize(with getSdk: @escaping () -> FeaturesInterface?) {
        self.getSdk = getSdk
    }

    fileprivate lazy var getSdk: GetSdk = { [self] in self.api }

    ///
    /// Represents all the features supported by Nimbus
    ///
    public let features = {{ nimbus_object }}Features()

    /// Clear all cached values for all features.
    /// This should be called after `applyPendingExperiments` is finished.
    public func invalidateCachedValues() {
        {% for f in self.iter_feature_defs() -%}
        features.{{- f.name()|var_name -}}.with(cachedValue: nil)
        {% endfor %}
    }

    ///
    /// A singleton instance of {{ nimbus_object }}
    ///
    public static let shared = {{ nimbus_object }}()
}

public class {{ nimbus_object }}Features {
    {%- for f in self.iter_feature_defs() %}
    {%- let raw_name = f.name() %}
    {%- let class_name = raw_name|class_name %}
    {{ f.doc()|comment("        ") }}
    public lazy var {{raw_name|var_name}}: FeatureHolder<{{class_name}}> = {
        FeatureHolder({{ nimbus_object }}.shared.getSdk, featureId: {{ raw_name|quoted }}) { (variables) in
            {{ class_name }}(variables)
        }
    }()
    {%- endfor %}
}


{%- for code in self.initialization_code() %}
{{ code }}
{%- endfor %}

// Public interface members begin here.
{% for code in self.declaration_code() %}
{{- code }}
{%- endfor %}

{% import "macros.kt" as kt %}