import React, { useEffect, useState } from "react";
import { Container } from "reactstrap";
import BreadCrumb from "Components/Common/BreadCrumb";
import { Card, Col, Row } from 'antd';
import axios from "axios";

const DashboardEcommerce = () => {
  document.title = "Redback Admin | Dashboard";

  const [userData, setUserData] = useState({
    allUsers: 0,
    activeUsers: 0,
    inactiveUsers: 0,
  });

  const getAuthToken = () => {
    const authUser = sessionStorage.getItem("authUser");
    if (authUser) {
      const parsedUser = JSON.parse(authUser);
      return parsedUser.token; // assuming the token is under 'token' key in the stored object
    }
    return null;
  };

  // Fetch user data from the APIs
  useEffect(() => {
    const fetchUserData = async () => {
      const token = getAuthToken(); // Get the token from sessionStorage
      if (!token) {
        console.error("No token found in sessionStorage");
        return;
      }

      try {
        // Set Authorization header with Bearer token
        const headers = {
          Authorization: `Token ${token}`,
        };

        // Make API requests with headers
        const allUsersResponse = await axios.get(
          `${process.env.REACT_APP_API_URL}/admin/all-users`,
          { headers }
        );
        const activeUsersResponse = await axios.get(
          `${process.env.REACT_APP_API_URL}/admin/active-users`,
          { headers }
        );
        const inactiveUsersResponse = await axios.get(
          `${process.env.REACT_APP_API_URL}/admin/inactive-users`,
          { headers }
        );

        // Set state with the data from the API responses
        setUserData({
          allUsers: allUsersResponse.data.length, // assuming the response has a count property
          activeUsers: activeUsersResponse.data.length,
          inactiveUsers: inactiveUsersResponse.data.length,
        });

        
      } catch (error) {
        console.error("Error fetching user data:", error);
      }
    };

    fetchUserData();
  }, []);
  
  return (
    <React.Fragment>
      <div className="page-content">
        <Container fluid>
          <BreadCrumb title="Redback Admin" pageTitle="Dashboard" />
          <Row gutter={16}>
            <Col span={8}>
              <Card title="All Users" variant="borderless">
                {userData.allUsers}
              </Card>
            </Col>
            <Col span={8}>
              <Card title="Active Users" variant="borderless">
              {userData.activeUsers}
              </Card>
            </Col>
            <Col span={8}>
              <Card title="Inactive Users" variant="borderless">
              {userData.inactiveUsers}
              </Card>
            </Col>
          </Row>
        </Container>
      </div>
    </React.Fragment>
  );
};

export default DashboardEcommerce;
