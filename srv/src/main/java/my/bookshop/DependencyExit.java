@Component
@ServiceName(DeploymentService.DEFAULT_NAME)
class DependencyExit implements EventHandler {
 
    @On(event = DeploymentService.EVENT_DEPENDENCIES)
    public void onGetDependencies(DependenciesEventContext context) {
 
        List<SaasRegistryDependency> dependencies = new ArrayList<>();
 
        dependencies.add(SaasRegistryDependency.create(getSDMXsappName()));
        context.setResult(dependencies);
    }
 private String getSDMXsappName() {
    List<ServiceBinding> allServiceBindings =
    DefaultServiceBindingAccessor.getInstance().getServiceBindings();
// filter for a specific binding
ServiceBinding sdmBinding =
    allServiceBindings.stream()
        .filter(binding -> "sdm".equalsIgnoreCase(binding.getServiceName().orElse(null)))
        .findFirst()
        .get();
Map<String, Object> uaaCredentials = sdmBinding.getCredentials();
Map<String, Object> uaa = (Map<String, Object>) uaaCredentials.get("uaa");
 return uaa.get("xsappname").toString();
    }
}
