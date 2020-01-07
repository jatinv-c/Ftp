/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ftpserverclient;

import java.util.ArrayList;
import java.util.List;
import org.apache.ftpserver.FtpServer;
import org.apache.ftpserver.FtpServerFactory;
import org.apache.ftpserver.ftplet.Authority;
import org.apache.ftpserver.ftplet.FtpException;
import org.apache.ftpserver.ftplet.UserManager;
import org.apache.ftpserver.listener.ListenerFactory;
import org.apache.ftpserver.usermanager.PropertiesUserManagerFactory;
import org.apache.ftpserver.usermanager.impl.BaseUser;
import org.apache.ftpserver.usermanager.impl.WritePermission;

/**
 *
 * @author Jatin.Vasnani
 */
public class CustomFtpServer {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws FtpException {
        PropertiesUserManagerFactory userManagerFactory = new PropertiesUserManagerFactory();
        UserManager userManager = userManagerFactory.createUserManager();
        
        List<Authority> authorities = new ArrayList<>();
        authorities.add(new WritePermission());        
        
        BaseUser user = new BaseUser();
        user.setName("username");
        user.setPassword("password");
        user.setHomeDirectory("/tmp/");
        userManager.save(user);       
        user.setAuthorities(authorities);

        ListenerFactory listenerFactory = new ListenerFactory();
        listenerFactory.setServerAddress("localhost");
        listenerFactory.setPort(2221);

        FtpServerFactory factory = new FtpServerFactory();
        factory.setUserManager(userManager);
        factory.addListener("default", listenerFactory.createListener());

        FtpServer server = factory.createServer();
        server.start();
    }
}
