package org.wildfly.vlog.glow.intro;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/")
@ApplicationScoped
public class DemoResource  {
    @Inject
    @ConfigProperty(name = "config.prop", defaultValue = "Stranger")
    private String configValue;

    @GET
    @Path("/")
    public String greeting() {
        return "Hello " + configValue;
    }
}
