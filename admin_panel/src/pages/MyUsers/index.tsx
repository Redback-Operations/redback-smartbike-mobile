import React, { useEffect, useState } from "react";
import { Container } from "reactstrap";
import BreadCrumb from "Components/Common/BreadCrumb";
import { Card, Col, Row, Table, Tag, Space, Switch } from 'antd';
import axios from "axios";
import type { TableProps } from 'antd';
import { ToastContainer, toast } from 'react-toastify';
interface DataType {
  key: string;
  id: string;
  email: string;
  username: string;
  user_created: string | null;
  is_active: boolean;
}

const MyUsers = () => {
  const [data, setData] = useState<DataType[]>([]);
  // const token = "your_token_here";

  const getAuthToken = () => {
    const authUser = sessionStorage.getItem("authUser");
    if (authUser) {
      const parsedUser = JSON.parse(authUser);
      return parsedUser.token; // assuming the token is under 'token' key in the stored object
    }
    return null;
  };

  const updateUserStatus = async (userId: string, isActive: boolean) => {
    const token = getAuthToken(); // Get the token from sessionStorage
    if (!token) {
      console.error("No token found in sessionStorage");
      return;
    }

    const headers = {
      Authorization: `Token ${token}`,
    };

    try {
      const response = await axios.patch(
        `${process.env.REACT_APP_API_URL}/admin/update_user_status/${userId}`,
        { is_active: isActive },
        { headers }
      );
      
      const message = response.data?.message || `User ${userId} status updated to ${isActive ? "Active" : "Inactive"}`;
      toast.success(message, {
        position: "top-right",
        autoClose: 3000,
        hideProgressBar: false,
        closeOnClick: false,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "light"
        });
       setData((prevData) =>
        prevData.map((user) =>
          user.id === userId ? { ...user, is_active: isActive } : user
        )
      );
    } catch (error) {
      console.error("Error updating user status:", error);
    }
  };

  useEffect(() => {
    const fetchUserData = async () => {
      const token = getAuthToken(); // Get the token from sessionStorage
      if (!token) {
        console.error("No token found in sessionStorage");
        return;
      }
  
      const headers = {
        Authorization: `Token ${token}`,  // Add Authorization header
      };
  
      try {
        const response = await axios.get(`${process.env.REACT_APP_API_URL}/admin/all-users`, { headers });
        const transformedData = response.data.map((user: any) => ({
          key: user.id,  // The key is required for each row in the table
          id: user.id,
          email: user.email,
          username: user.username,
          user_created: user.user_created || 'N/A', // Handle null values
          is_active: user.is_active,
        }));
        setData(transformedData);
      } catch (error) {
        console.error('Error fetching user data:', error);
      }
    };
  
    fetchUserData(); // Call the function to fetch data
  
  }, []); 

  const columns: TableProps<DataType>['columns'] = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
    },
    {
      title: 'Email',
      dataIndex: 'email',
      key: 'email',
    },
    {
      title: 'Username',
      dataIndex: 'username',
      key: 'username',
    },
    {
      title: 'User Created',
      dataIndex: 'user_created',
      key: 'user_created',
    },
    {
      title: 'Active',
      dataIndex: 'is_active',
      key: 'is_active',
      render: (isActive: boolean) => (
        <Tag color={isActive ? 'green' : 'volcano'}>
          {isActive ? 'Active' : 'Inactive'}
        </Tag>
      ),
    },
      {
      title: 'Action',
      dataIndex: 'is_active',
      key: 'is_active',
      render: (isActive: boolean, record: any) => (
        <Switch
          checked={isActive}
          onChange={(checked: boolean) => {
            updateUserStatus(record.id, checked); // Update status when switch is toggled
          }}
        />
      ),
    },
  ];

  return (
    <React.Fragment>
      <div className="page-content">
        <Container fluid>
        <ToastContainer />
          <BreadCrumb title="My Users" pageTitle="Users" />

          {/* Ant Design Card container */}
          <Row>
            <Col span={24}>
              <Card title="User List" bordered={false}>
                {/* Ant Design Table */}
                <Table<DataType> columns={columns} dataSource={data} />
              </Card>
            </Col>
          </Row>
        </Container>
      </div>
    </React.Fragment>
  );
}

export default MyUsers;
